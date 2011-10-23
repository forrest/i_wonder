class Hash
  def delete_blank
    delete_if{|k, v| v.blank? or v.instance_of?(Hash) && v.delete_blank.blank?}
  end
end