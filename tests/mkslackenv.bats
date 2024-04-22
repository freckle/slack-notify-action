# shellcheck disable=SC2030,SC2031
bats_load_library bats-support
bats_load_library bats-assert

src=$(cd "$BATS_TEST_DIRNAME/.." && pwd)
export GITHUB_ACTION_PATH=$src
export "PATH=$GITHUB_ACTION_PATH/bin:$PATH"

# Example commit and Job Run from megarepo
export GITHUB_JOB=backend-hoogle-image
export GITHUB_REPOSITORY=freckle/megarepo
export GITHUB_RUN_ID=8757571976
export GITHUB_WORKFLOW="Backend Hoogle"
export INPUTS_COMMIT_SHA=6b0eb9f99b7b50e50fea219dc2f585c8cbc93d17
export INPUTS_EVENT_NAME=
export INPUTS_SLACK_USERS=
export INPUTS_SLACK_USERS_FILE=

@test "failure with all optional inputs omitted" {
  export JOB_STATUS=failure

  run bash -c "echo | mkslackenv"
  assert_output - <<'EOASSERT'
SLACK_TITLE=Backend Hoogle backend-hoogle-image failed
SLACK_COLOR=danger
SLACK_MESSAGE<<EOM
pbrisbin committed <https://github.com/freckle/megarepo/commit/6b0eb9f99b7b50e50fea219dc2f585c8cbc93d17|6b0eb9f> 3 days ago (2024-04-19T17:45:25Z)

EOM
SLACK_FOOTER=https://github.com/freckle/megarepo/actions/runs/8757571976/job/24036522054
EOASSERT
}

@test "with extra message" {
  export JOB_STATUS=failure

  run bash -c "echo hi there | mkslackenv"
  assert_output - <<'EOASSERT'
SLACK_TITLE=Backend Hoogle backend-hoogle-image failed
SLACK_COLOR=danger
SLACK_MESSAGE<<EOM
pbrisbin committed <https://github.com/freckle/megarepo/commit/6b0eb9f99b7b50e50fea219dc2f585c8cbc93d17|6b0eb9f> 3 days ago (2024-04-19T17:45:25Z)
hi there
EOM
SLACK_FOOTER=https://github.com/freckle/megarepo/actions/runs/8757571976/job/24036522054
EOASSERT
}

@test "success" {
  export JOB_STATUS=success

  run bash -c "echo | mkslackenv"
  assert_output - <<'EOASSERT'
SLACK_TITLE=Backend Hoogle backend-hoogle-image succeeded
SLACK_COLOR=success
SLACK_MESSAGE<<EOM
pbrisbin committed <https://github.com/freckle/megarepo/commit/6b0eb9f99b7b50e50fea219dc2f585c8cbc93d17|6b0eb9f> 3 days ago (2024-04-19T17:45:25Z)

EOM
SLACK_FOOTER=https://github.com/freckle/megarepo/actions/runs/8757571976/job/24036522054
EOASSERT
}

@test "custom event name" {
  export INPUTS_EVENT_NAME="My awesome job"
  export JOB_STATUS=success

  run bash -c "echo | mkslackenv"
  assert_output - <<'EOASSERT'
SLACK_TITLE=My awesome job succeeded
SLACK_COLOR=success
SLACK_MESSAGE<<EOM
pbrisbin committed <https://github.com/freckle/megarepo/commit/6b0eb9f99b7b50e50fea219dc2f585c8cbc93d17|6b0eb9f> 3 days ago (2024-04-19T17:45:25Z)

EOM
SLACK_FOOTER=https://github.com/freckle/megarepo/actions/runs/8757571976/job/24036522054
EOASSERT
}

@test "reading slack users" {
  export INPUTS_SLACK_USERS='{"pbrisbin":"U6PM52FPY"}'
  export JOB_STATUS=success

  run bash -c "echo | mkslackenv"
  assert_output - <<'EOASSERT'
SLACK_TITLE=Backend Hoogle backend-hoogle-image succeeded
SLACK_COLOR=success
SLACK_MESSAGE<<EOM
<@U6PM52FPY> committed <https://github.com/freckle/megarepo/commit/6b0eb9f99b7b50e50fea219dc2f585c8cbc93d17|6b0eb9f> 3 days ago (2024-04-19T17:45:25Z)

EOM
SLACK_FOOTER=https://github.com/freckle/megarepo/actions/runs/8757571976/job/24036522054
EOASSERT
}

@test "reading slack users via contents" {
  export INPUTS_SLACK_USERS_FILE=.github/slack.json
  export JOB_STATUS=success

  run bash -c "echo | mkslackenv"
  assert_output - <<'EOASSERT'
SLACK_TITLE=Backend Hoogle backend-hoogle-image succeeded
SLACK_COLOR=success
SLACK_MESSAGE<<EOM
<@U6PM52FPY> committed <https://github.com/freckle/megarepo/commit/6b0eb9f99b7b50e50fea219dc2f585c8cbc93d17|6b0eb9f> 3 days ago (2024-04-19T17:45:25Z)

EOM
SLACK_FOOTER=https://github.com/freckle/megarepo/actions/runs/8757571976/job/24036522054
EOASSERT
}

@test "unknown slack users" {
  export INPUTS_SLACK_USERS='{}'
  export JOB_STATUS=success

  run bash -c "echo | mkslackenv"
  assert_output - <<'EOASSERT'
SLACK_TITLE=Backend Hoogle backend-hoogle-image succeeded
SLACK_COLOR=success
SLACK_MESSAGE<<EOM
<@unknown> committed <https://github.com/freckle/megarepo/commit/6b0eb9f99b7b50e50fea219dc2f585c8cbc93d17|6b0eb9f> 3 days ago (2024-04-19T17:45:25Z)

EOM
SLACK_FOOTER=https://github.com/freckle/megarepo/actions/runs/8757571976/job/24036522054
Your username is missing from slack-notify users mapping.

Without your username present in this file, Slack notifications may not
highlight you correctly.

::group::Expand for instructions to find your Slack User Id

1. View your profile
2. Click the three-dots in the upper section
3. Select "Copy member ID"

::endgroup::
::error title=Your username is missing from slack-notify users::Please add your GitHub username as a key, with Slack User ID as value
EOASSERT
}
