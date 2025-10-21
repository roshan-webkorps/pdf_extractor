module Buyers
  class BuyerFactory
    def self.prompt_for(buyer)
      case buyer
      when "levis" then Levis::Prompt.build
      when "pvh_tommy" then PvhTommy::Prompt.build
      else raise ArgumentError, "Unknown buyer: #{buyer}"
      end
    end

    def self.mapper_for(buyer)
      case buyer
      when "levis" then Levis::Mapper
      when "pvh_tommy" then PvhTommy::Mapper
      else raise ArgumentError, "Unknown buyer: #{buyer}"
      end
    end
  end
end
