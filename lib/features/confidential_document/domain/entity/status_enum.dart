enum SyncStatus {
  synced,         // Le fichier est à jour sur les deux supports
  pendingDelete,  // Supprimé en local, doit être supprimé sur Supabase
  pendingDownload      // Existe sur local, doit être téléchargé sur Supabase
}
