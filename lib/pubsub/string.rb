class String
  #Return substring from start to last occurrence separator. In the block form, return all substring
  # "test/test1/test2".sub_before("/") {|item| puts item}
  # test/test1/test2
  # test/test1
  # test
  def sub_before(separator)
    result = self
    index = size
    begin
      result = result[0, index]
      next if result.empty?
      break unless block_given?
      yield result
    end while index = result.rindex('/')
    result
  end
end