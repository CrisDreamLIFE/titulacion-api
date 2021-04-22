class Proposal < ApplicationRecord
    has_one_attached :fileTest
    require 'student_summary'

    def estudianteConCorreo(email)
        estudiante = StudentSummary.where(email: email).take
    end
end

