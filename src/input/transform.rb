module Input
  class StringTransform < Parslet::Transform
    rule(:char => simple(:c)) { c }
    rule(:esc => simple(:c)) { c }
    rule(:str => sequence(:chars)) { chars.join }
  end

  class NetsimTransform < Parslet::Transform
    rule(:char => simple(:c)) { c }
    rule(:int => simple(:s)) { s.to_i }
    rule(:float => simple(:s)) { s.to_f }
    rule(:amount => simple(:n), :bw_unit => simple(:u)) {
      BANDWIDTH_UNITS[u.to_s] * n
    }
    rule(:amount => simple(:n), :time_unit => simple(:u)) {
      TIME_UNITS[u.to_s] * n
    }
    rule(:statement => {:simulator => {:identifier => simple(:id)}, :call => subtree(:call)}) {
      call.merge(:simulator => id)
    }
    rule(:statement => {:assignment => subtree(:assignment)}) {
      {:assignment => assignment}
    }

    def apply obj, context=nil
      @st ||= StringTransform.new
      obj = @st.apply(obj)
      super.apply(obj, context)
    end
  end
end
