class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy]

  def index
    @teams = Team.all
  end

  def show
    if Assign.where(user_id: current_user.id).where(team_id: @team.id).present?
      @working_team = @team
      change_keep_team(current_user, @team)
    else
      redirect_to dashboard_url, notice: "権限がありません"
    end
  end

  def new
    @team = Team.new
  end

  def edit
    unless Assign.where(user_id: current_user.id).where(team_id: @team.id).present?
      redirect_to dashboard_url, notice: "権限がありません"
    end
  end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: 'チーム作成に成功しました！'
    else
      render :new
    end
  end

  def update
    owner = @team.owner_id
    if @team.owner_id == current_user.id
      if @team.update(owner_id: params[:team][:owner_id]) && owner != @team.owner_id
        @user = User.find(@team.owner_id)
        LeaderMailer.leader_mail(@user).deliver
        redirect_to @team, notice: 'リーダー権限を変更しました'
      elsif @team.update(team_params)
        redirect_to @team, notice: 'チーム更新に成功しました!'
      else
        render :edit
      end
    else
      redirect_to dashboard_url, notice: "権限がありません "
    end
  end

  def destroy
    if @team.owner_id == current_user.id
      @team.destroy
      redirect_to teams_url, notice: 'チーム削除に成功しました！'
    else
      redirect_to teams_url, notcie: '権限がありません'
    end
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end


  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end

end
