import 'dart:ui' as ui;

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
  int? id;  // auto increment id in database
  int? uid; // user set id
  final int plotId;
  double? diameter;
  ui.Image? displayImage;
  double locationLatitude;
  double locationLongitude;
  double? orientation;
  int? speciesId;
  bool isEucalyptus;
  TreeCondition condition;
  TreeAliveCondition? conditionDetail;
  String? causeOfDeath;
  double? age;
  String? diameterUrl;
  String? species;
  String? speciesUrl;
  String? lineJson; // line of trunk edges
  String? locationsJson; // List of locations when user is capturing diameter

  Tree({
    this.id,
    this.uid,
    required this.plotId,
    this.diameter,
    this.displayImage,
    required this.locationLatitude,
    required this.locationLongitude,
    this.orientation,
    this.speciesId,
    required this.isEucalyptus,
    required this.condition,
    this.conditionDetail,
    this.causeOfDeath,
    this.age,
    this.diameterUrl,
    this.species,
    this.speciesUrl,
    this.locationsJson,
    this.lineJson
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

enum PhysicalMechanism {
  standing("Standing", "a"),
  broken("Broken (snapped trunk)", "b"),
  uprooted("Uprooted (root tip-up)", "c"),
  probablyStanding("Standing or broken, probably standing (not uprooted)", "d"),
  probablyBroken("Standing or broken, probably broken (not uprooted)", "e"),
  notUprooted("Standing or broken (not uprooted)", "f"),
  probablyUprooted("Broken or uprooted, probably uprooted", "g"),
  probablyBrokenUprooted("Broken or uprooted, probably broken", "h"),
  notStanding("Broken or uprooted (not standing)", "i"),
  vanished("Vanished (found location, tree looked for but not found)", "k"),
  presumedDead("Presumed dead (location of tree not found e.g. problems, poor maps, etc.)", "l"),
  unknown("Unknown", "m");

  final String detail;
  final String statusCode;

  const PhysicalMechanism(this.detail, this.statusCode);
}

enum NumTreesInMortality {
  diedAlone("Died alone", "p"),
  oneOfMultipleDeaths("One of multiple deaths", "q"),
  unknown("Unknown", "r");

  final String detail;
  final String statusCode;

  const NumTreesInMortality(this.detail, this.statusCode);
}

enum KillProcess {
  anthropogenic("Anthropogenic", "j"),
  burnt("Burnt", "n"),
  lightning("Lightning", "o"),
  unknownKilled("Unknown whether killed or killed", "s"),
  killer("Killer of at least one other tree >10cm DBH", "t"),
  killedNoMoreInfo("Killed, no more information", "u"),
  killedBroken("Killed by tree that died broken", "v"),
  killedUprooted("Killed by another tree that uprooted", "w"),
  killedBranchesDead("Killed by branches from dead standing tree", "x"),
  killedBranchesLiving("Killed by branches fallen from living tree", "y"),
  killedStrangler("Killed by strangler", "z"),
  killedLiana("Killed by liana", "2"),
  killedWeight("Killed by strangler / liana weight [tree died broken or fallen]", "3"),
  killedCompetition("Killed by strangler / liana competition [tree died standing]", "4"),
  killedElephant("Killed by elephant", "5"),
  killedTermites("Killed by termites", "6"),
  killedWind("Killed by wind", "7");

  final String detail;
  final String statusCode;

  const KillProcess(this.detail, this.statusCode);
}

class PlotWithTrees {
  final Plot plot;
  final List<Tree> trees;

  PlotWithTrees({required this.plot, required this.trees});
}
