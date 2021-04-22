class Activity < ApplicationRecord
    belongs_to :work_plan
    has_many :task
    has_many :commentary
end
