require 'errors'

class TransferService
  def self.call(from_user_id, to_user_id, amount)
    raise 'Amount can not be negative!' if amount.negative? # well, this is ugly

    User.transaction do
      users = User.where(id: [from_user_id, to_user_id]).lock
      raise ActiveRecord::RecordNotFound unless users.size == 2

      from_user = users.find { |u| u.id == from_user_id }
      to_user = users.find { |u| u.id == to_user_id }
      
      from_user.balance -= amount
      to_user.balance += amount

      raise NotEnoughMoney if from_user.balance.negative?

      from_user.save!
      to_user.save!
    end
  end
end

