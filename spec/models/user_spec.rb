RSpec.describe User do
  describe "associations" do
    it { is_expected.to have_many :entities_users }
    it { is_expected.to have_many(:entities).through(:entities_users) }
  end
end
