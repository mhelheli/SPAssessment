# SPAssessment

Assessment SharePoint Online avant migration, en PowerShell uniquement : existence du site, template, nombre de bibliothèques et de fichiers. Disponible en module PowerShell et en agent GitHub Copilot.

## Démarrage rapide
```powershell
git clone https://github.com/mhelheli/SPAssessment.git
Install-Module PnP.PowerShell -Scope CurrentUser
Import-Module .\SPAssessment\SPAssessment.psd1
Invoke-SPAssessment -InputCsv .\SPAssessment\sites.sample.csv -ClientId <guid> -OutputCsv .\report.csv -OutputHtml .\report.html
```

## Agent Copilot
Ouvrir le dossier dans VS Code, choisir l'agent `sp-assessment` dans Copilot Chat et lui donner les URLs des sites.

## Contenu
- `SPAssessment/` : module PowerShell (voir son [README](SPAssessment/README.md) pour les prérequis et les colonnes du rapport)
- `.github/agents/sp-assessment.agent.md` : agent Copilot
- `Package.ps1` : génère un zip partageable
