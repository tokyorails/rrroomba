module ByteProcessing

  def signed_integer(bytes)
    case bytes.size
    when 1
      return (bytes[0] & ~(1 << 7)) - (bytes[0] & (1 << 7))
    when 2
      sixteenbit = bytes[0] << 8 | bytes[1]
      return (sixteenbit & ~(1 << 15)) - (sixteenbit & (1 << 15))#http://en.wikipedia.org/wiki/Two%27s_complement#Calculating_two.27s_complement
    end
  end

end
