require 'errors'

class TransferService
  def self.call(from_user_id, to_user_id, amount)
    User.transaction do
      users = User.where(id: [from_user_id, to_user_id]).lock
      from_user = users.find { |u| u.id == from_user_id } || (raise ActiveRecord::RecordNotFound)
      to_user = users.find { |u| u.id == to_user_id } || (raise ActiveRecord::RecordNotFound)
      
      from_user.balance -= amount
      to_user.balance += amount

      raise NotEnoughMoney if from_user.balance.negative?

      from_user.save!
      to_user.save!
    end
  end
end

