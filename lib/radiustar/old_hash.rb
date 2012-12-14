# only patch for ruby 1.8
if (RUBY_VERSION =~ /^1\.8/) == 0
  #
  # Monkey-patch the default ruby version < 1.9.0 Hash class to provide
  # the same interface to the radiustar libs.
  #
  class Hash
    # Implementation of the ruby-1.9.x key function:
    # http://www.ruby-doc.org/core-1.9.3/Hash.html#method-i-key
    def key(value)
      self.index value
    end
  end
end
