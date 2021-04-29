(function afterLogin() {
  let urlParams = new URLSearchParams(window.location.search);
  let login = urlParams.get("login");
  let deploy = urlParams.get("deploy");
  let deployEnv = urlParams.get("environment");
  let commitSha = urlParams.get("commit_sha");
  if (login === "success" && deploy === "true" && commitSha !== undefined && commitSha !== '' && deployEnv !== undefined && deployEnv !== '') {
    onAfterSuccessLogin(commitSha, deployEnv);
  }
})();

function onDeployButtonClick(commitSha, deployEnv) {
  gitHubAuth(commitSha, deployEnv);
}

function onAfterSuccessLogin(commitSha, deployEnv) {
  const rowId = `${deployEnv}-deploy`;
  const progressLabel = getProgressLabelNode();
  document.getElementById(rowId).querySelector("button").disabled = "disabled";
  document.getElementById(rowId).appendChild(progressLabel);
  const inProgressTimer = setInterval(
    (lbl, initialText) => {
      if (lbl.innerText !== initialText) lbl.innerText = initialText;
      else lbl.innerText += "...";
    },
    1000,
    progressLabel,
    progressLabel.innerText
  );

  triggerDeploy()
    .then((responseStatus) => {
      if (
        responseStatus === 401 ||
        responseStatus === 403 ||
        responseStatus === 422
      ) {
        return gitHubAuth(commitSha, deployEnv);
      }
      else if (responseStatus === 204){
        const deployWorkflowUrl = "https://github.com/DFE-Digital/apply-for-teacher-training/actions/workflows/deploy.yml";
        document.getElementById(`${deployEnv}-deploy`).appendChild(getAnchorNode(deployWorkflowUrl, deployEnv))
      }
    })
    .then(() => {
      clearInterval(inProgressTimer);
      document.getElementById(rowId).removeChild(progressLabel);
      setTimeout((_) => {
        window.location.replace(window.location.origin);
      }, 30000);
    })
    .catch((error) => {
      logError(error);
    });
}

function gitHubAuth(commitSha, deployEnv) {
  const headers = new Headers();
  headers.append("Accept", "*/*");

  let callbackUri = `http://localhost:5000/login?environment=${deployEnv}&commit_sha=${commitSha}`;
  let gitHubAuthUrl = new URL("https://github.com/login/oauth/authorize");
  gitHubAuthUrl.searchParams.append("client_id", "62a9613d9f0b2b073dce");
  gitHubAuthUrl.searchParams.append("redirect_uri", callbackUri);
  gitHubAuthUrl.searchParams.append("state", "KuVaJNysxgQy");
  gitHubAuthUrl.searchParams.append("scope", "repo");

  window.location.href = gitHubAuthUrl.href;
}

function triggerDeploy(commitSha, deployEnv) {
  const headers = new Headers();
  headers.append("Accept", "*/*");
  headers.append("Content-Type", "application/json");

  const requestOptions = {
    method: "POST",
    headers: headers,
    redirect: "follow",
  };

  return fetch(`/webhooks/trigger-deployment`, requestOptions)
    .then((response) => response.status)
    .catch(logError);
}

function getAnchorNode(link, env) {
  var anchor = document.createElement("a");
  anchor.href = link;
  anchor.className =
    "govuk-heading-m app-banner app-banner--small app-banner--progress";
  anchor.innerText = `🚀 Deployment to ${env} in progress 🚀`;
  anchor.style.color = "#000";

  return anchor;
}

function getProgressLabelNode() {
  var label = document.createElement("label");
  label.className = "govuk-label";
  label.innerText = `🚧 Please wait while deployment begins`;
  label.style.color = "#fff";

  return label;
}

function logError(error) {
  console.log(error);
}
