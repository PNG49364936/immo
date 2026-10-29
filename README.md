# Pierres de Paris

Les ventes immobilières des 2 dernières années disponibles (24 mois) dans les 20 arrondissements de Paris, ainsi qu'à Clichy et Levallois-Perret, sur une carte.

## Lancer l'app

```bash
bundle install
bin/rails db:setup     # crée la base et charge les contours des arrondissements
bin/rails dvf:import   # télécharge les ventes DVF (environ 10 s)
bin/dev                # http://localhost:3000
```

Les données se mettent aussi à jour depuis l'app, avec le bouton « Rafraîchir les données ».

## Sources

- **Ventes** : [DVF géolocalisées](https://files.data.gouv.fr/geo-dvf/latest/csv/) (Etalab), départements 75 et 92, publiées deux fois par an avec environ 6 mois de retard.
- **Contours** : [arrondissements](https://opendata.paris.fr/explore/dataset/arrondissements/) (Ville de Paris) et communes via [geo.api.gouv.fr](https://geo.api.gouv.fr).
- **Fond de carte** : CARTO Positron, avec MapLibre GL.

## Filtres appliqués aux ventes

On garde uniquement les ventes (`nature_mutation = Vente`) d'**un seul** appartement ou d'une seule maison, éventuellement avec une cave ou un parking. Les surfaces doivent faire au moins 9 m² et le prix au m² doit être compris entre 2 000 et 40 000 €. Voir `app/services/dvf/parser.rb`.
