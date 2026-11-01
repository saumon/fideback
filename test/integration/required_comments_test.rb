require "test_helper"

class RequiredCommentsTest < ActionDispatch::IntegrationTest
  def submit_path(respondent = respondents(:rose)) = submit_respondent_form_path(token: respondent.token)
  def form_path(respondent = respondents(:rose)) = respondent_form_path(token: respondent.token)

  # Une réponse par managé et par question : la note de la question à note et le commentaire de chacune.
  def answers_for(subjects: [ subjects(:dana), subjects(:eli) ], rating: "4", quality_body: "Bien", strengths_body: "Fiable")
    subjects.index_by { |subject| subject.id.to_s }.transform_values do |_|
      { questions(:quality).id.to_s => { "rating" => rating, "body" => quality_body }, questions(:strengths).id.to_s => { "body" => strengths_body } }
    end
  end

  test "a submission without any comment is refused and flags each missing comment" do
    post submit_path, params: { answers: answers_for(quality_body: "", strengths_body: "") }

    assert_response :unprocessable_entity
    assert_not respondents(:rose).reload.submitted?
    assert_select ".error", text: "Commentaire manquant", count: 4
    assert_select ".error", text: "Note manquante", count: 0
    assert_select ".toast, .flash", text: /Il manque 4 champs : complétez ceux qui sont signalés avant de soumettre\./
  end

  test "a single missing comment is announced in the singular" do
    answers = answers_for
    answers[subjects(:eli).id.to_s][questions(:strengths).id.to_s]["body"] = ""
    post submit_path, params: { answers: answers }

    assert_response :unprocessable_entity
    assert_select ".error", text: "Commentaire manquant", count: 1
    assert_select ".flash", text: /Il manque 1 champ : complétez celui qui est signalé avant de soumettre\./
  end

  test "a submission with nothing filled counts every expected field" do
    post submit_path, params: { answers: {} }

    assert_response :unprocessable_entity
    assert_select ".flash", text: /Il manque 6 champs/
    assert_select ".error", text: "Note manquante", count: 2
    assert_select ".error", text: "Commentaire manquant", count: 4
  end

  test "notes and comments typed before the refusal are kept in the form" do
    answers = answers_for(quality_body: "Très bien", strengths_body: "")
    post submit_path, params: { answers: answers }

    assert_response :unprocessable_entity
    assert_select "textarea[name='answers[#{subjects(:dana).id}][#{questions(:quality).id}][body]']", text: "Très bien"
    assert_select "input[name='answers[#{subjects(:dana).id}][#{questions(:quality).id}][rating]'][value='4']"
  end

  test "a comment of two characters is enough" do
    post submit_path, params: { answers: answers_for(quality_body: "ok", strengths_body: "ok") }

    assert_redirected_to form_path
    assert respondents(:rose).reload.submitted?
  end

  test "a comment of spaces only counts as missing" do
    post submit_path, params: { answers: answers_for(quality_body: "   ", strengths_body: "\n \n") }

    assert_response :unprocessable_entity
    assert_not respondents(:rose).reload.submitted?
    assert_select ".error", text: "Commentaire manquant", count: 4
  end

  test "saving without submitting accepts missing comments" do
    patch form_path, params: { answers: answers_for(quality_body: "", strengths_body: "") }

    assert_redirected_to form_path
    assert_not respondents(:rose).reload.submitted?
    assert_equal 2, respondents(:rose).answers.where.not(rating: nil).count
  end

  test "a respondent who saved only notes before must complete the comments to submit" do
    patch form_path, params: { answers: answers_for(quality_body: "", strengths_body: "") }

    post submit_path, params: { answers: answers_for(quality_body: "", strengths_body: "") }
    assert_response :unprocessable_entity
    assert_not respondents(:rose).reload.submitted?

    post submit_path, params: { answers: answers_for }
    assert respondents(:rose).reload.submitted?
  end

  test "a respondent who already submitted keeps their answers and is not asked again" do
    answer_fully(respondents(:sam))
    respondents(:sam).update!(submitted_at: Time.current)

    get form_path(respondents(:sam))

    assert_response :success
    assert_select ".callout", text: /Vous avez soumis vos réponses/
  end

  test "every note and comment carries the required mention and is counted by the progress controller" do
    get form_path

    assert_select ".answer-form[data-controller=answer-progress]"
    assert_select ".required-hint", text: "obligatoire pour soumettre", count: 6
    assert_select "[data-answer-progress-target=field]", count: 6
    assert_select "label", text: "Commentaire", count: 4
    assert_select ".answer-progress[role=status][aria-live=polite]", text: "Il reste 6 champs à renseigner."
  end

  test "the progress starts from what is already saved" do
    patch form_path, params: { answers: answers_for(quality_body: "", strengths_body: "") }

    get form_path

    assert_select ".answer-progress", text: "Il reste 4 champs à renseigner."
    assert_select ".answer-progress.is-done", count: 0
  end

  test "the progress says everything is filled once nothing is left" do
    answer_fully(respondents(:sam))

    get form_path(respondents(:sam))

    assert_select ".answer-progress.is-done", text: "Tout est renseigné : vous pouvez soumettre."
  end

  test "the first missing field gets the autofocus after a refusal" do
    post submit_path, params: { answers: {} }
    assert_select "[autofocus]", count: 1
    assert_select "input[autofocus][name='answers[#{subjects(:dana).id}][#{questions(:quality).id}][rating]']"

    answers = answers_for
    answers[subjects(:eli).id.to_s][questions(:strengths).id.to_s]["body"] = ""
    post submit_path, params: { answers: answers }
    assert_select "[autofocus]", count: 1
    assert_select "textarea[autofocus][name='answers[#{subjects(:eli).id}][#{questions(:strengths).id}][body]']"
  end

  test "no autofocus on a form that was not refused" do
    get form_path

    assert_select "[autofocus]", count: 0
  end

  test "a submitted form shows no mention and no counter" do
    answer_fully(respondents(:sam))
    respondents(:sam).update!(submitted_at: Time.current)

    get form_path(respondents(:sam))

    assert_select ".required-hint", count: 0
    assert_select ".answer-progress", count: 0
    assert_select ".answer-form[data-controller]", count: 0
  end

  test "a closed campaign shows no mention and no counter" do
    campaigns(:running_campaign).close!

    get form_path

    assert_select ".required-hint", count: 0
    assert_select ".answer-progress", count: 0
  end
end
