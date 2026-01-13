class CardModel {
    final String name;
    final String picturePath;
    final DateTime? expiryDate;

    CardModel({required this.name, required this.picturePath, this.expiryDate});

    // vérifie si la carte de fidélité n'est pas expirée
    bool isValid() {
      return expiryDate!.isAfter(DateTime.now());
    }
}