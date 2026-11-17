# SPAssessment

Module PowerShell 7 d'assessment SharePoint Online avant migration. Pour chaque site : existence, titre, template, nombre de bibliothèques et de fichiers.

## Prérequis
1. PowerShell 7+
2. `Install-Module PnP.PowerShell -Scope CurrentUser`
3. Une app registration Entra ID (ClientId) pour PnP, avec le consentement du tenant :
   `Register-PnPEntraIDAppForInteractiveLogin -ApplicationName "SPAssessment" -Tenant contoso.onmicrosoft.com`

## Utilisation
```powershell
Import-Module .\SPAssessment\SPAssessment.psd1
Invoke-SPAssessment -InputCsv .\SPAssessment\sites.sample.csv -ClientId <guid> -OutputCsv .\report.csv
```
Le CSV d'entrée doit avoir une colonne `Url`.

Pour ajouter un rapport HTML : `-OutputHtml .\report.html`.

## Colonnes du rapport
`Url, Exists, Title, Template, LibraryCount, TotalFiles, LibraryDetails, Status, Error`

Notes :
- `TotalFiles` est la somme des `ItemCount` des bibliothèques de documents visibles (les dossiers sont inclus).
- `Status` : `OK`, `NotFound` ou `Error` (ex. accès refusé).
- Le compte utilisé doit avoir au moins un accès en lecture à chaque site.

## Utilisation de l'agent Copilot
Le dépôt inclut l'agent `sp-assessment` (`.github/agents/sp-assessment.agent.md`).
1. `git clone https://github.com/mhelheli/SPAssessment.git` puis ouvrir le dossier dans VS Code (GitHub Copilot Chat requis).
2. Dans le chat Copilot, sélectionner l'agent `sp-assessment`.
3. Demander par exemple : « Évalue ces sites : https://contoso.sharepoint.com/sites/A ». L'agent demande le `ClientId` si besoin, lance le module et résume le rapport.

## Partage
Copier le dossier `SPAssessment` (zip) vers `$HOME\Documents\PowerShell\Modules\`, ou le publier dans une galerie PowerShell interne.
