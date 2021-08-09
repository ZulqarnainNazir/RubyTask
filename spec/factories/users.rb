FactoryBot.define do
  factory :user do
    sequence :email do |n|
	    "user#{n}@example.com"
  	end
    password { "testuser123" }
    admin { false }

    trait :admin do
      admin { true }
    end
  end
end