# Les utilisateurs du site sont les managers : les sondés n'ont pas de compte.
class Admin::UsersController < Admin::BaseController
  def index
    @managers = Manager.order(created_at: :desc, id: :desc)
  end
end
