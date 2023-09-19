class Flag < ApplicationRecord
  KEY_TOO_MUCH_TRAFFIC = :too_much_traffic

  def self.too_much_traffic?
    where(key: KEY_TOO_MUCH_TRAFFIC).any?
  end

  def self.too_much_traffic!
    create(key: KEY_TOO_MUCH_TRAFFIC)
  end

  def self.ok_traffic!
    where(key: KEY_TOO_MUCH_TRAFFIC).delete_all
  end
end
