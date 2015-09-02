module Contract

  def methods *method_names
    define_singleton_method(:implemented_by) do |impl|
      new(impl)
    end
    private_class_method(:new)

    define_method(:create_method) do |name, &block|
      self.class.send(:define_method, name, &block)
    end
    private(:create_method)

    define_method(:delegate_to_impl) do |method_names|
      method_names.each do |method_name|
        create_method method_name do |*arguments|
          @impl.send(method_name, *arguments)
        end
      end
    end
    private(:delegate_to_impl)

    define_method(:check_all_methods_implemented) do |impl|
      not_implemented = method_names.select do |method_name|
        not impl.respond_to?(method_name)
      end
      raise NotAllMethodsImplemented.new(not_implemented) unless not_implemented.empty?
    end
    private(:check_all_methods_implemented)

    define_method(:initialize) do |impl|
      check_all_methods_implemented(impl)
      instance_variable_set(:"@impl", impl)
      delegate_to_impl method_names
    end
    private(:initialize)
  end

  class NotAllMethodsImplemented < Exception
    def initialize not_implemented_methods
      super("Not implemented #{not_implemented_methods.to_s}")
    end
  end
end
