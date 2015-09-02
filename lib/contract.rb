module Contract

  def methods *method_names

    define_method(:create_method) do |name, &block|
      self.class.send(:define_method, name, &block)
    end

    define_method(:delegate_to_impl) do |method_names|
      method_names.each do |method_name|
        create_method method_name do |*arguments|
          @impl.send(method_name, *arguments)
        end
      end
    end

    define_method(:check_all_methods_implemented) do |impl|
      not_implemented = method_names.select do |method_name|
        not impl.respond_to?(method_name)
      end
      raise NotAllMethodsImplemented.new(not_implemented) unless not_implemented.empty?
    end

    define_method(:initialize) do |impl|
      check_all_methods_implemented(impl)
      instance_variable_set(:"@impl", impl)
      delegate_to_impl method_names
    end
  end

  class NotAllMethodsImplemented < Exception
    def initialize not_implemented_methods
      super("Not implemented #{not_implemented_methods.to_s}")
    end
  end

end
