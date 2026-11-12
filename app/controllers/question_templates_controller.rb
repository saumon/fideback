class QuestionTemplatesController < ApplicationController
  before_action :set_template, only: %i[show edit update destroy]
  before_action :refuse_system_template, only: %i[edit update destroy]

  def index
    @templates = QuestionTemplate.available_to(current_manager).includes(:items)
  end

  def show
  end

  def new
    @template = current_manager.question_templates.build
    @template.items.build(rating: true, comment: true)
  end

  def create
    @template = current_manager.question_templates.build(template_params)
    if @template.save
      redirect_to question_templates_path, notice: "Modèle créé."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @template.update(template_params)
      redirect_to question_templates_path, notice: "Modèle mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @template.destroy
    redirect_to question_templates_path, notice: "Modèle supprimé.", status: :see_other
  end

  private

  # Le modèle du système et les modèles du manager, jamais ceux d'un autre : ils sont introuvables.
  def set_template
    @template = QuestionTemplate.available_to(current_manager).find(params[:id])
  end

  def refuse_system_template
    redirect_to @template, alert: "Le modèle par défaut est fourni par Fideback : il ne se modifie ni ne se supprime.", status: :see_other if @template.system?
  end

  def template_params
    params.expect(question_template: [ :name, items_attributes: [ [ :id, :position, :prompt, :rating, :comment, :_destroy ] ] ])
  end
end
