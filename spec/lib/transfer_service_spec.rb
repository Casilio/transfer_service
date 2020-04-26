require 'rails_helper'
require 'transfer_service' # autoload?

describe TransferService do
  before(:each) do
    @user1 = User.create(name: 'user1', balance: 20)
    @user2 = User.create(name: 'user2')
  end

  context 'pass incorrect user ids' do
    it 'raises ActiveRecord::RecordNotFound' do
      expect { TransferService.call(nil, nil, 1) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { TransferService.call(@user1.id, nil, 1) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { TransferService.call(nil, @user2.id, 1) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'not enough money on sender\'s balance' do
    it 'raises NotEnoughMoney' do
      expect { TransferService.call(@user1.id, @user2.id, 30) }. to raise_error(NotEnoughMoney)
    end
  end

  context 'valid agruments and enough money' do
    it 'transfer money between users' do
      TransferService.call(@user1.id, @user2.id, 10)

      expect(@user1.reload.balance).to eq(10)
      expect(@user2.reload.balance).to eq(10)
    end
  end
end
