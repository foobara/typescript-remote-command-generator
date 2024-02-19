module Foobara
  module Generators
    class WriteGeneratedFilesToDisk < Foobara::Command
      inputs do
        output_directory :string, :required
      end
    end
  end
end
