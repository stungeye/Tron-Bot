class Array
  def select_largest
    weighted = inject({}) { |h,v| h.merge( { v => yield(v) }) }
    max = weighted.values.max
    largest = weighted.select { |k,f| f == max }
    largest.inject([]) { |a,v| a << v[0] }
  end
  
  def select_smallest
    weighted = inject({}) { |h,v| h.merge( { v => yield(v) }) }
    min = weighted.values.min
    smallest = weighted.select { |k,f| f == min }
    smallest.inject([]) { |a,v| a << v[0] }
  end
end
