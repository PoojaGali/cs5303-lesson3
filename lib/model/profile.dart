class Profile {
  String? docId; //Firestore auto generated id
  late String email;
  late DateTime signUpDate;
  late String description;
  late String name;

//key for firestore documents
  static const DESCRIPTION = 'description';
  static const USER_EMAIL = 'user_email';
  static const SIGNUP_DATE = 'signup_date';
  static const NAME = 'name';

  Profile({
    this.docId,
    this.email = '',
    DateTime? signUpDate,
    this.description = '',
    this.name = '',
  }) : this.signUpDate = signUpDate ?? DateTime.now();

  Profile.clone(Profile p) {
    this.docId = p.docId;
    this.email = p.email;
    this.signUpDate = p.signUpDate;
    this.description = p.description;
    this.name = p.name;
  }

  void assign(Profile p) {
    this.docId = p.docId;
    this.email = p.email;
    this.signUpDate = p.signUpDate;
    this.description = p.description;
    this.name = p.name;
  }

  Map<String, dynamic> toFirestoreDoc() {
    return <String, dynamic>{
      DESCRIPTION: this.description,
      SIGNUP_DATE: this.signUpDate,
      NAME: this.name,
      USER_EMAIL: this.email,
    };
  }

  static Profile fromFirestoreDoc(Map<String, dynamic> doc, String docId) {
    return Profile(
      docId: docId,
      email: doc[USER_EMAIL],
      name: doc[NAME],
      description: doc[DESCRIPTION],
      signUpDate: doc[SIGNUP_DATE] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[SIGNUP_DATE].millisecondsSinceEpoch)
          : DateTime.now(),
    );
  }
}
