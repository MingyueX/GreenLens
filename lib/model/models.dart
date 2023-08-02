class Farmer {
  final int? id;
  final String name;
  final int participantId;

  Farmer({this.id, required this.name, required this.participantId});
}

class Plot {
  final int? id;
  final int farmerId;
  final int clusterId;
  final int groupId;
  final int farmId;
  final DateTime date;
  final bool harvesting;
  final bool thinning;
  final String dominantLandUse;

  Plot({
    this.id,
    required this.farmerId,
    required this.clusterId,
    required this.groupId,
    required this.farmId,
    required this.date,
    required this.harvesting,
    required this.thinning,
    required this.dominantLandUse,
  });

  @override
  String toString() {
    return 'Plot{id: $id, farmerId: $farmerId, clusterId: $clusterId, groupId: $groupId, farmId: $farmId, date: $date, harvesting: $harvesting, thinning: $thinning, dominantLandUse: $dominantLandUse}';
  }
}

enum LandUse {
  water,
  bare,
  savannah,
  city,
  treeFarm,
  fieldCropFarm,
  forestPreserve,
  other;

  get name {
    switch (this) {
      case LandUse.water:
        return "Water";
      case LandUse.bare:
        return "Bare";
      case LandUse.savannah:
        return "Savannah";
      case LandUse.city:
        return "City/Village/Town";
      case LandUse.treeFarm:
        return "Tree Farm";
      case LandUse.fieldCropFarm:
        return "Field Crop Farm";
      case LandUse.forestPreserve:
        return "Forest Preserve";
      case LandUse.other:
        return "Other";
    }
  }
}

class Tree {
  final int? id;
  final int plotId;
  final double? diameter;
  final double locationLatitude;
  final double locationLongitude;
  final double? orientation;
  final int? speciesId;
  final bool isEucalyptus;
  final TreeCondition condition;
  final TreeAliveCondition? conditionDetail;
  final String? causeOfDeath;

  Tree({
    this.id,
    required this.plotId,
    this.diameter,
    required this.locationLatitude,
    required this.locationLongitude,
    this.orientation,
    this.speciesId,
    required this.isEucalyptus,
    required this.condition,
    this.conditionDetail,
    this.causeOfDeath,
  });
}

enum TreeCondition {
  alive,
  notFound,
  noLongerExist;

  get name {
    switch (this) {
      case TreeCondition.alive:
        return "ALIVE";
      case TreeCondition.notFound:
        return "NOT FOUND";
      case TreeCondition.noLongerExist:
        return "NO LONGER EXIST";
    }
  }

  static TreeCondition fromString(String str) {
    return TreeCondition.values.firstWhere(
          (e) => e.name == str,
      orElse: () => throw Exception("This condition does not exist"),
    );
  }
}

enum TreeAliveCondition {
  normal("Normal", "a"),
  broken("Broken stem/top & resprouting, or at least live phloem/xylem", "b"),
  leaning("Leaning by ≥10%", "c"),
  fallen("Fallen", "d"),
  fluted("Tree fluted or/fenestrated", "e"),
  hollow("Hollow", "f"),
  rotten("Rotten and or presence of bracket fungus", "g"),
  multiStemmed("Multiple stemmed individual", "h"),
  noLeaves("No leaves, few leaves", "i"),
  burnt("Burnt", "j"),
  snapped("Snapped < 1.3m", "k"),
  liana("Has liana ≥10cm diameter on stem or in canopy", "l"),
  coveredByLianas("Covered by lianas", "m"),
  newRecruit("New recruit", "n"),
  lightningDamage("Lightning damage", "o"),
  cut("Cut", "p"),
  peelingBark("Peeling bark", "q"),
  hasStrangler("Has a strangler", "s"),
  hasWound("Has wound and/or cambium exposed", "w"),
  elephantDamage("Elephant damage", "x"),
  termiteDamage("Termite damage", "y"),
  decliningProductivity("Declining productivity", "z");

  const TreeAliveCondition(this.detail, this.statusCode);

  final String detail;
  final String statusCode;

  static TreeAliveCondition? fromString(String? str) {
    if (str == null) {
      return null;
    }
    return TreeAliveCondition.values.firstWhere(
          (e) => e.statusCode == str,
      orElse: () => throw Exception("This condition does not exist"),
    );
  }
}