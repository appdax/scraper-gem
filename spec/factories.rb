
class SpecPartial < AppDax::Partial
  def attr
    123
  end

  def nil_attr
    nil
  end

  def available?
    true
  end
end

class SpecMultiPartial < AppDax::MultiPartial
  def initialize(data)
    super data, SpecPartial
  end
end

class SpecStock < AppDax::Stock
  def isin
    'DE12345678'
  end

  def my_partial
    SpecPartial.new({})
  end

  def my_multi_partial
    SpecMultiPartial.new([{}])
  end
end

class SpecFeed < AppDax::Feed
  age_from :my_partial
  meta(:meta_tag) { 'meta_value' }
  kpis_from my_partial: [:attr, :nil_attr]
  kpi(:complex_attr) { 'test' }
end

class SpecMultiFeed < AppDax::MultiFeed
  age_from :my_multi_partial
  meta(:meta_tag) { 'meta_value' }
  kpis_from my_multi_partial: [:attr, :nil_attr]
  kpi(:complex_attr) { 'test' }
end

class SpecSerializer < AppDax::Serializer
  feeds SpecFeed
  source :spec
end

class SpecScraper < AppDax::Scraper
  stock_class SpecStock
  serializer_class SpecSerializer
  fields :macd
  content_type :json
  base_url 'http://www.bloomberg.com/markets/api/security/time-series/study'
  url_for_field { |kpi, sym| "#{base_url}/#{kpi}/#{sym}?timeFrame=1_MONTH" }
end
