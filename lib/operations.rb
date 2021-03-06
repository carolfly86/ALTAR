require 'timeout'
require 'csv'
def ds_learning(script)
  dbname = script[0...-4]
  script_type = script[-3]
  query_json = JSON.parse(File.read("sql/#{dbname}/#{script}.json"))
  f_options_list = []
  t_options = {}

  beginTime = Time.now

  query_json.each do |key, value|
    if key == 'T'
      query = value['query']
      pk_list = value['pkList']
      t_options = { query: query, pkList: pk_list, table: 't_result' }
      # tqueryObj = QueryObj.new(t_options)
    end
  end

  tqueryObj = QueryObj.new(t_options)

  tqueryObj.predicate_tree_construct('t', true, 0)

  satisfied_tbl = tqueryObj.create_satisfied_tbl
  attributes = tqueryObj.relevant_cols()
  # attributes = tqueryObj.all_cols.select do |col|
  #                col.typcategory != 'U'
  #               end
  dcm = DecisionTreeMutation.new(attributes)
  if script_type == 'j'
    puts 'ignore join...'
    # excluded_tbl = tqueryObj.create_join_excluded_tbl
    # dcm.python_training(satisfied_tbl,excluded_tbl,dbname,script, false, nil ,2)
  else
    excluded_tbl = tqueryObj.create_excluded_tbl
    dcm.python_training(satisfied_tbl,excluded_tbl,dbname,script, false, nil, 3)
  end
  endTime = Time.now
  duration = (endTime - beginTime).to_i
  puts "#{script} duration: #{duration}"

end

def faultLocalization(script, golden_record_opr, method, auto_fix)
  # method: b --- baseline SBFL methods
  #         o --- original
  #         n --- new
  # dbname = script.split('_')[0]
  dbname = script[0...-4]
  script_type = script[-3]
  query_json = JSON.parse(File.read("sql/#{dbname}/#{script}.json"))
  create_test_result_tbl
  create_fix_result_tbl
  f_options_list = []
  t_options = {}
  query_json.each do |key, value|
    if key == 'F'
      value.each do |opt|
        query = opt['query']
        pk_list = opt['pkList']
        relevent = opt['relevent']
        # pp relevent
        f_options = { query: query, pkList: pk_list, table: 'f_result', relevent: relevent }
        f_options_list << f_options
      end

    elsif key == 'T'
      query = value['query']
      pk_list = value['pkList']
      t_options = { query: query, pkList: pk_list, table: 't_result' }
      # tqueryObj = QueryObj.new(t_options)
    end
  end

  tqueryObj = QueryObj.new(t_options)

  # pp tqueryObj.parseTree
  # return
  # create Golden record
  if method != 'b'
    createGR(golden_record_opr, script, tqueryObj)
  else
    tqueryObj.predicate_tree_construct('t', true, 0)
  end
  # pp 'test'
  f_options_list.each_with_index do |f_options, idx|
    puts "#{idx}:****************************************"
    fix_rst_list = []
    fl_rst_list = []

    fqueryObj = QueryObj.new(f_options)
    if method == 'b'
      beginTime = Time.now
      is_join = script_type == 'j'
      tarantular = Tarantular.new(fqueryObj, tqueryObj, 1, is_join)
      tarantular.predicateTest
      endTime = Time.now
      duration = (endTime - beginTime).to_i
      mw_duration = duration
      tarantular_duration = duration - tarantular.mw_duration
      tarantular_rank = tarantular.relevence(f_options[:relevent])
      total_test_cnt = tarantular.total_test_cnt
      m_u_tuple_count = tarantular.failed_tuple_count
      binding.pry if m_u_tuple_count == 0
      totalScore = m_u_tuple_count
      fix_rst = {'test_type' => 'w', 'query' => fqueryObj.query,
          'm_u_tuple_count' => m_u_tuple_count,
          'duration' => duration,
          'tarantular_rank' => tarantular_rank,
          'tarantular_duration' => tarantular_duration,
          'mw_duration' => mw_duration,
          'total_test_cnt' => total_test_cnt
          }
      fl_rst_list << fix_rst
    else
      tarantular_duration = 0
      tarantular_rank = { 'tarantular_rank' => '0', 'ochihai_rank' => '0', 'naish2_rank' => '0', 'kulczynski2_rank' => '0',
                          'wong1_rank' => '0', 'sober_rank' => '0', 'liblit_rank' => '0', 'mw_rank' => '0', 'crosstab_rank' => '0',
                          'tarantular_hm' => '0', 'ochihai_hm' => '0', 'naish2_hm' => '0', 'kulczynski2_hm' => '0',
                          'wong1_hm' => '0', 'sober_hm' => '0', 'liblit_hm' => '0', 'mw_hm' => '0', 'crosstab_hm' => '0' }
      total_test_cnt = 0

      puts 'begin fault localization'
      beginTime = Time.now
      puts "fault localization start time: #{beginTime}"
      localizeErr = LozalizeError.new(fqueryObj, tqueryObj)
      m_u_tuple_count = localizeErr.missing_tuple_count + localizeErr.unwanted_tuple_count

      if script_type == 'j'

        puts 'fault localize: Join Key Errors'
        fl_jc_start_time = Time.now
        new_join_key,old_join_key = localizeErr.join_key_err
        fl_jc_end_time = Time.now
        # puts fl_jc_end_time
        fl_jc_duration = (fl_jc_end_time - beginTime).to_i
        # update_test_result_tbl(idx, 'jc',fqueryObj.query, tqueryObj.query, 0, fl_jc_duration, 0, f_options[:relevent], 0, 0, 0)
        fix_rst = {'test_type' => 'jc',
          'query' => fqueryObj.query,
          'm_u_tuple_count' => 0,
          'duration' => fl_jc_duration,
          'tarantular_rank' => tarantular_rank,
          'tarantular_duration' => tarantular_duration,
          'mw_duration' => tarantular_duration,
          'total_test_cnt' => total_test_cnt
          }
        fl_rst_list << fix_rst

        if new_join_key.count >0
          puts 'finding candidate join key list'
          fqueryObj = fix_join_cond(new_join_key,old_join_key,fqueryObj,fix_rst_list)
          # Reinitialize LocalizeErr with fixed query
          localizeErr = LozalizeError.new(fqueryObj, tqueryObj)
        else
          puts 'No Join Key Error'
        end
        

        # # Join type error localization
        puts 'fault localize: Join Type Errors'
        fl_jt_start_time = Time.now
        joinErrList = localizeErr.join_type_err
        fl_jt_end_time = Time.now
        puts fl_jt_end_time
        fl_jt_duration = (fl_jt_end_time - beginTime).to_i
        # update_test_result_tbl(idx, 'jt',fqueryObj.query, tqueryObj.query, 0, fl_jt_duration, 0, f_options[:relevent], 0, 0, 0)
        fix_rst = {'test_type' => 'jt', 'query' => fqueryObj.query,
          'm_u_tuple_count' => 0,
          'duration' => fl_jt_duration,
          'tarantular_rank' => tarantular_rank,
          'tarantular_duration' => tarantular_duration,
          'mw_duration' => tarantular_duration,
          'total_test_cnt' => total_test_cnt
          }
        fl_rst_list << fix_rst

        if joinErrList.count > 0
          # fix join type error
          fqueryObj = fix_join_type(joinErrList,fqueryObj,fix_rst_list)
          # Reinitialize LocalizeErr with fixed query
          localizeErr = LozalizeError.new(fqueryObj, tqueryObj)

        else
          puts 'No Join Type Error'
        end

      end


      # if fqueryObj.has_where_predicate?()
      if script_type == 'w'
        # Where condition fault localization
        localizeErr.selecionErr(method)
        fqueryObj.score = localizeErr.getSuspiciouScore
        puts 'fquery score:'
        pp fqueryObj.score
        # totalScore = fqueryObj.score['totalScore']
        totalScore = localizeErr.missing_tuple_count + localizeErr.unwanted_tuple_count
        if auto_fix
          test_result = localizeErr.get_test_result
          totalScore = fix_where_cond(tqueryObj,fqueryObj,test_result,dbname,script,idx,method,fix_rst_list,f_options[:relevent].count()*3)
        end
      else
        # binding.pry
        totalScore = localizeErr.missing_tuple_count + localizeErr.unwanted_tuple_count
      end

      puts 'fault localization end'
      endTime = Time.now
      puts "fault localization end time: #{endTime}"

      # Projection error localization
      # prjErrList = localizeErr.projErr

      duration = (endTime - beginTime).to_i
      puts "duration: #{duration}"

      puts "total_score: #{totalScore}"

    end
    # pp tarantular_rank
    # return
    # tarantular_rank = tarantular.relevence(f_options[:relevent])
    # return



    # update fl result table
    fl_rst_list.each do |r|
      update_test_result_tbl(idx,r['test_type'],r['query'],
       tqueryObj.query, r['m_u_tuple_count'], r['duration'], 
       totalScore, f_options[:relevent], r['tarantular_rank'], 
       r['tarantular_duration'], r['mw_duration'],r['total_test_cnt'])
    end
    # update fix result table
    fix_rst_list.each do |r|
      # binding.pry
      score = r['score'].nil? ? totalScore : r['score']
      update_fix_result_tbl(idx,r['test_type'],tqueryObj.query,r['query'],duration, score)
    end
  end
end

def xdiff(file,query_type)
  data = Array.new
  CSV.foreach(file, { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
    data << row.to_hash
  end
  header = data[0].keys
  header << 'similarity'
  new_file = File.dirname(file)+'/newresult.csv'
  CSV.open(new_file, "wb") do |csv|
    csv << header
    data.each do |row|
      next if row[:tquery].to_s.empty?
      tquery = row[:tquery].to_s.gsub('"','')
      fixed_query = row[:fixed_query].to_s.gsub('"','')

      if query_type == 'j'
        similarity = XDiff.join_compare(tquery,fixed_query)
      elsif query_type == 'w'
        t_predicateTree = build_pdtree_from_query(tquery, row[:test_id])
        fixed_predicateTree = build_pdtree_from_query(fixed_query, row[:test_id])
        similarity = XDiff.where_compare(t_predicateTree,fixed_predicateTree)
      end

      result = row.values
      result << similarity
      csv << result
    end
  end

end

def build_pdtree_from_query(query,test_id)
  parse_tree = PgQuery.parse(query).parsetree[0]
  fromPT =  parse_tree['SELECT']['fromClause']
  wherePT = parse_tree['SELECT']['whereClause']

  root = Tree::TreeNode.new('root', '')
  predicateTree = PredicateTree.new('t', true, test_id)
  predicateTree.build_full_pdtree(fromPT[0], wherePT, root)
  return predicateTree
end
# def randomMutation(fqueryObj, tqueryObj)
#   # options = {:script=> script, :table =>'f_result' }
#   # fqueryObj = QueryObj.new(options)
#   # pp fqueryObj

#   # t_options = {:script=> 'true', :table =>'t_result' }
#   # tqueryObj = QueryObj.new(t_options)
#   # pp tqueryObj
#   tqueryObj.create_stats_tbl
#   newQ = fqueryObj.generate_neighbor_program(127, 0)
# end

