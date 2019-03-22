class AgendaDeleteMailer < ApplicationMailer
  default from: 'from@example.com'

  def agenda_delete_mail(team_member)
    @user = team_member.user
    mail to: @user.email, subject: 'アジェンダが削除されました'
  end
end
