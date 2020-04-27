require 'rails_helper'
require 'transfer_service'

describe TransferService do
  before(:each) do
    @user1 = User.create(name: 'user1', balance: 20)
    @user2 = User.create(name: 'user2')
  end

  context 'receive invalid user ids' do
    it 'raises ActiveRecord::RecordNotFound' do
      expect { TransferService.call(nil, nil, 1) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { TransferService.call(@user1.id, nil, 1) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { TransferService.call(nil, @user2.id, 1) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'not enough money on sender\'s balance' do
    it 'raises NotEnoughMoney' do
      expect { TransferService.call(@user1.id, @user2.id, 30) }.to raise_error(NotEnoughMoney)
    end
  end

  context 'receive negative amount' do
    it 'raises RuntimeError' do
      expect { TransferService.call(@user1.id, @user2.id, -20) }.to raise_error(RuntimeError, 'Amount can not be negative!')
    end
  end

  context 'valid agruments and enough money' do
    it 'transfer money between users' do
      TransferService.call(@user1.id, @user2.id, 10)

      expect(@user1.reload.balance).to eq(10)
      expect(@user2.reload.balance).to eq(10)
    end

    it 'transfer all money' do
      TransferService.call(@user1.id, @user2.id, 20)

      expect(@user1.reload.balance).to be_zero
      expect(@user2.reload.balance).to eq(20)
    end
  end
end
