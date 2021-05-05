const msalConfig = {
  auth: {
    authority:
      "https://login.microsoftonline.com/9c7d9dd3-840c-4b3f-818e-552865082e16",
    clientId: "6f057dad-8513-4020-8de7-14141bfc1f79",
  },
  cache: {
    cacheLocation: "sessionStorage",
    storeAuthStateInCookie: true,
  },
};

const msalInstance = new Msal.UserAgentApplication(msalConfig);

function onDeployButtonClick(commitSha, deployEnv) {
  const rowId = `${deployEnv}-deploy`;
  const progressLabel = getProgressLabelNode();
  document.getElementById(rowId).querySelector("button").disabled = "disabled";
  document.getElementById(rowId).appendChild(progressLabel);
  const inProgressTimer = setInterval(
    (lbl, initialText) => {
      if (lbl.innerText !== initialText) lbl.innerText = initialText;
      else lbl.innerText += "...";
    }, 1000, progressLabel, progressLabel.innerText);

  getAccount()
    .then((response) => {
      if (response.tokenType === "access_token") {
        return triggerBuild(commitSha, response.accessToken, deployEnv);
      } else {
        return acquireAccessToken().then((token) =>
          triggerBuild(commitSha, token, deployEnv)
        );
      }
    })
    .then(() => {
      clearInterval(inProgressTimer);
      document.getElementById(rowId).removeChild(progressLabel);
      setTimeout( _ => window.location.reload(), 30000);
    })
    .catch((error) => {
      logError(error);
      signIn();
    });
}

function getAccount() {
  const account = msalInstance.getAccount();
  if (account) {
    return ssoSilent(account.userName);
  } else {
    return signIn();
  }
}

function ssoSilent(userName) {
  const ssoRequest = {
    loginHint: userName,
  };

  return msalInstance
    .ssoSilent(ssoRequest)
    .then((response) => {
      console.log("ssoResponse", response);
      return response;
    })
    .catch((error) => {
      logError(error);
      signIn();
    });
}

function signIn() {
  const loginRequest = {
    scopes: ["499b84ac-1321-427f-aa17-267ca6975798/user_impersonation"],
  };

  return msalInstance
    .loginPopup(loginRequest)
    .then((response) => {
      return response;
    })
    .catch(logError);
}

function acquireAccessToken() {
  var tokenRequest = {
    scopes: ["499b84ac-1321-427f-aa17-267ca6975798/user_impersonation"],
  };

  return msalInstance
    .acquireTokenSilent(tokenRequest)
    .then((response) => {
      return response.accessToken;
    })
    .catch((error) => {
      if (error.name === "InteractionRequiredAuthError") {
        return msalInstance
          .acquireTokenPopup(tokenRequest)
          .then((response) => {
            return response.accessToken;
          })
          .catch(logError);
      }
    });
}

function triggerBuild(commitSha, accessToken, deployEnv) {
  const headers = new Headers();
  const tokenBearer = "Bearer " + accessToken;
  headers.append("Authorization", tokenBearer);
  headers.append("Accept", "*/*");
  headers.append("Content-Type", "application/json");

  const deployToProduction = deployEnv === "production";

  const parameters = {
    deploy_production: deployToProduction,
    deploy_sandbox: false,
    deploy_staging: !deployToProduction,
  };

  const requestBody = {
    definition: {
      id: 325,
    },
    parameters: JSON.stringify(parameters),
    sourceBranch: "refs/heads/master",
    sourceVersion: commitSha.trim(),
  };

  const requestOptions = {
    method: "POST",
    headers: headers,
    body: JSON.stringify(requestBody),
    redirect: "follow",
  };

  const azurePipelinesBuildApi =
    "https://dev.azure.com/dfe-ssp/Become-A-Teacher/_apis/build/builds?api-version=6.0";

  fetch(`/webhooks/deploy-in-progress?target_environment=${deployEnv}`, requestOptions)
  .then((response) => console.log(response))
  .catch(logError);

  return fetch(azurePipelinesBuildApi, requestOptions)
    .then((response) => {
      console.log(response);
      return response.json();
    })
    .then((body) => body._links.web.href)
    .then((link) =>
      document.getElementById(`${deployEnv}-deploy`).appendChild(getAnchorNode(link, deployEnv))
    ).catch(logError);
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

function signOut() {
  msalInstance.logout();
}

function logError(error) {
  console.log(error);
}
