function sauver_figure(fig, nom)
% SAUVER_FIGURE  Enregistre la figure en PNG (150 dpi) dans ./figures/
% puis la ferme. Les figures ne s'affichent pas a l'ecran : elles sont
% toutes ecrites sur disque pour que main.m tourne sans interaction.
dossier = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~exist(dossier, 'dir'), mkdir(dossier); end
print(fig, fullfile(dossier, [nom '.png']), '-dpng', '-r150');
close(fig);
end
