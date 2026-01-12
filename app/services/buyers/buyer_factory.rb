module Buyers
  class BuyerFactory
    def self.prompt_for(buyer)
      case buyer
      when "levis" then Levis::Prompt.build
      when "pvh_tommy" then PvhTommy::Prompt.build
      when "asos" then Asos::Prompt.build
      when "kontoor" then Kontoor::Prompt.build
      when "bestseller" then Bestseller::Prompt.build
      when "bestseller_domestic" then BestsellerDomestic::Prompt.build
      when "barbour" then Barbour::Prompt.build
      when "ll_bean" then LlBean::Prompt.build
      else raise ArgumentError, "Unknown buyer: #{buyer}"
      end
    end

    def self.mapper_for(buyer)
      case buyer
      when "levis" then Levis::Mapper
      when "pvh_tommy" then PvhTommy::Mapper
      when "asos" then Asos::Mapper
      when "kontoor" then Kontoor::Mapper
      when "bestseller" then Bestseller::Mapper
      when "bestseller_domestic" then BestsellerDomestic::Mapper
      when "barbour" then Barbour::Mapper
      when "ll_bean" then LlBean::Mapper
      else raise ArgumentError, "Unknown buyer: #{buyer}"
      end
    end
  end
end
