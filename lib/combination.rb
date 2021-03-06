require_relative 'integer_helper'
require 'pry'
require 'fortune'
module Comb_Calculator
  def self.num_of_combination(dominator, subordinator)
    if dominator.even?
      new_sub = subordinator > dominator / 2 ? dominator - subordinator : subordinator
    else
      new_sub = subordinator > (dominator - 1) / 2 ? dominator - subordinator + 1 : subordinator
    end
    dominator.bounded_fact(new_sub) / new_sub.fact

    # Fortune::C.calc(:elements => dominator, :select => subordinator)
    # dominator.fact/(subordinator.fact*(dominator-subordinator).fact)
  end

  def self.sum_of_comnibations(dominator, s, e)
    # puts "dominator: #{dominator}"
    # puts "s: #{s}"
    # puts "e: #{e}"
    # if e < 0 || s < 0 || s > e
    initial = (e - s + 1).even? ? 0 : num_of_combination(dominator, e)
    # puts initial
    sum = (s + 1..e).step(2).reduce(initial) { |sum, n| sum + num_of_combination(dominator + 1, n) }
    # { |product, n| product * n }
    # s = s+1
    # while s<=e do
    #   sum = sum + self.num_of_combination(dominator+1,s)
    #   s = s+2
    # end
    sum
  end

  def self.opt_sum_of_comnibations(dominator, s, e)
    return 0 if e == 0
    puts "opt dominator: #{dominator}"
    puts "opt s: #{s}"
    puts "opt e: #{e}"
    sum_of_comb_mid = 2 ^ (dominator - 1)
    # dominator.even? ? (2^n - self.num_of_combination(dominator,dominator/2))/2 : 2^(dominator-1)
    mid = dominator.even? ? dominator / 2 : (dominator - 1) / 2
    sum = 0
    if s == 0
      if mid > e
        # e is less than mid
        if mid - e < e
          # distance from e to mid is smaller than 0 to e
          sum = sum_of_comb_mid - Comb_Calculator.sum_of_comnibations(dominator, e + 1, mid)
        else
          # distance from e to mid is larger than 0 to e
          sum = Comb_Calculator.sum_of_comnibations(dominator, s, e)
        end
      elsif mid == e
        # e is the mid
        sum = dominator.even? ? sum_of_comb_mid + Comb_Calculator.num_of_combination(dominator, dominator / 2) : sum_of_comb_mid
      else
        # e is larger than mid
        if e == dominator
          # e is dominator
          sum = 2 ^ dominator
        elsif (mid - e).abs < dominator - e
          # distance from mid to e is smaller than e to n
          sum = sum_of_comb_mid + Comb_Calculator.sum_of_comnibations(dominator, mid + 1, e)
        else
          # distance from e to mid is larger than 0 to e
          sum = 2 ^ dominator - Comb_Calculator.sum_of_comnibations(dominator, e + 1, dominator)
        end
      end
    else
      if (s == mid) && (e == dominator)
        sum = dominator.even? ? sum_of_comb_mid + Comb_Calculator.num_of_combination(dominator, dominator / 2) : sum_of_comb_mid
      else
        if e - s > dominator - e + s
          sum = 2 ^ dominator - Comb_Calculator.sum_of_comnibations(dominator, 0, s - 1)
          if e < dominator
            sum = sum - sum_of_comnibations(dominator, e + 1, dominator)
          end
        else
          sum = Comb_Calculator.sum_of_comnibations(dominator, s, e)
        end
      end
    end
    sum
  end
end
