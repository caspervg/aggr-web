class TrueClass
  def sparql_escape
    '"true"^^xsd:boolean'
  end
end

class FalseClass
  def sparql_escape
    '"false"^^xsd:boolean'
  end
end

class Time
  def sparql_escape
    '"' + self.xmlschema + '"^^xsd:dateTime'
  end
end
