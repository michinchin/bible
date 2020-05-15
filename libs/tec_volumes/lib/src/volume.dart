import 'package:meta/meta.dart';

enum VolumeType {
  /* 0 */ anyType,
  /* 1 */ bible,
  /* 2 */ notUsedCommentary,
  /* 3 */ studyContent,
  /* 4 */ notUsedDevo,
  /* 5 */ audioBible,
  /* 6 */ category,
}

@immutable
class Volume {
  final int id;
  final VolumeType type;
  final int version;

  final String name;
  final String abbreviation;
  final String publisher;
  final String author;

  final String language;
  final bool isLatinBased;
  final bool normalize;

  final bool isStreamable;
  final bool isUpdateAvailable;
  final bool isPremium;

  const Volume({
    this.id,
    this.type,
    this.version,
    this.name,
    this.abbreviation,
    this.publisher,
    this.author,
    this.language,
    this.normalize,
    this.isLatinBased,
    this.isStreamable,
    this.isUpdateAvailable,
    this.isPremium,
  });
}

@immutable
class VolumePurchaseInfo {
  final bool isPurchasable;

  final int associatedVolumeId;
  final bool isAssociatedWithPurchase;

  final bool requiresAccountForTrial;

  final bool hasSubvolumeInApps;
  final List<Subvolume> subvolumes;

  const VolumePurchaseInfo({
    this.isPurchasable,
    this.associatedVolumeId,
    this.isAssociatedWithPurchase,
    this.requiresAccountForTrial,
    this.hasSubvolumeInApps,
    this.subvolumes,
  });
}

@immutable
class Subvolume {
  final String name;
  final int rangeStart;
  final int rangeLength;
  final bool isFree;
  final String price;
  final String retailPrice;
  final String identifier;

  const Subvolume({
    this.name,
    this.rangeStart,
    this.rangeLength,
    this.isFree,
    this.price,
    this.retailPrice,
    this.identifier,
  });
}

@immutable
class Category {
  final int id;
  final String name;
  final int position;

  final List<Volume> volumes;
  final List<Category> subcategories;

  const Category({
    this.id,
    this.name,
    this.position,
    this.volumes,
    this.subcategories,
  });
}
