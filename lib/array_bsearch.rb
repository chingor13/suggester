class Array
  # 
  # The binary search algorithm is extracted from Jon Bentley's
  # Programming Pearls 2nd ed. p.93
  #

  #
  # Return the lower boundary. (inside)
  #
  def bsearch_lower_boundary (range = 0 ... self.length, &block)
    lower  = range.first() -1
    upper = if range.exclude_end? then range.last else range.last + 1 end
    while lower + 1 != upper
      mid = ((lower + upper) / 2).to_i # for working with mathn.rb (Rational)
      if yield(self[mid]) < 0
	      lower = mid
      else 
      	upper = mid
      end
    end
    return upper
  end

  #
  # This method searches the FIRST occurrence which satisfies a
  # condition given by a block in binary fashion and return the 
  # index of the first occurrence. Return nil if not found.
  #
  def bsearch_first (range = 0 ... self.length, &block)
    boundary = bsearch_lower_boundary(range, &block)
    if boundary >= self.length || yield(self[boundary]) != 0
      return nil
    else 
      return boundary
    end
  end

  alias bsearch bsearch_first

  #
  # Return the upper boundary. (outside)
  #
  def bsearch_upper_boundary (range = 0 ... self.length, &block)
    lower  = range.first() -1
    upper = if range.exclude_end? then range.last else range.last + 1 end
    while lower + 1 != upper
      mid = ((lower + upper) / 2).to_i # for working with mathn.rb (Rational)
      if yield(self[mid]) <= 0
        lower = mid
      else
        upper = mid
      end
    end
    return lower + 1 # outside of the matching range.
  end

  #
  # This method searches the LAST occurrence which satisfies a
  # condition given by a block in binary fashion and return the 
  # index of the last occurrence. Return nil if not found.
  #
  def bsearch_last (range = 0 ... self.length, &block)
    # `- 1' for canceling `lower + 1' in bsearch_upper_boundary.
    boundary = bsearch_upper_boundary(range, &block) - 1

    if (boundary <= -1 || yield(self[boundary]) != 0)
      return nil
    else
      return boundary
    end
  end

  #
  # Return the search result as a Range object.
  #
  def bsearch_range (range = 0 ... self.length, &block)
    lower = bsearch_lower_boundary(range, &block)
    upper = bsearch_upper_boundary(range, &block)
    return lower ... upper
  end
end

