#
# Monkey-patch the default ruby version < 1.9.0 Hash class to provide
# the same interface to the radiustar libs.
#
class Hash
  unless {}.respond_to?(:key)
    alias_method :key, :index
  end
end

