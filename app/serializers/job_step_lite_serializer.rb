class JobStepLiteSerializer < ActiveModel::Serializer
  attributes :source, :beginDelimiter, :endDelimiter, :refresh

  def beginDelimiter
    '----BEGIN PANAMAX DATA----'
  end

  def endDelimiter
    '----END PANAMAX DATA----'
  end

  def refresh
    true
  end
end
