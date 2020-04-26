require 'transfer_service'

# Looking for deadlocks

user1 = User.find_or_create_by!(name: 'user1', balance: 0)
user2 = User.find_or_create_by!(name: 'user2', balance: 0)

user1.balance = 100
user1.save!

def cycle_transfer
  user1 = User.find_by(name: 'user1')
  user2 = User.find_by(name: 'user2')

  TransferService.call(user1.id, user2.id, 100)
  TransferService.call(user2.id, user1.id, 100)
rescue NotEnoughMoney
  p 'Not enough money. But it\'s ok, this time'
end

t1 = Thread.new do
  100.times do
    user1.reload.balance += 100
    user1.save!
  end
end

t2 = Thread.new do
  100.times do
    cycle_transfer
  end
end


t3 = Thread.new do
  100.times do
    user2.reload.balance += 100
    user2.save! if user2.balance >= 0
  end
end

t1.join
t2.join
t3.join

p 'Finished'
p user1.reload.balance
p user2.reload.balance
