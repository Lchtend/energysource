import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Float "mo:base/Float";
import Array "mo:base/Array";
import Result "mo:base/Result";
import Iter "mo:base/Iter";

actor {
  // Enerji kaynağı yapısı
  type EnergySource = {
    name : Text;
    efficiencyPercentage : Float;
    annualOutputKwh : Float;
    installationCost : Float;
    maintenanceCostPerYear : Float;
  };

  // Enerji kaynaklarını saklamak için HashMap
  let energySources = HashMap.HashMap<Text, EnergySource>(10, Text.equal, Text.hash);

  // Yeni bir enerji kaynağı ekleme
  public func addEnergySource(
    name : Text, 
    efficiencyPercentage : Float, 
    annualOutputKwh : Float,
    installationCost : Float,
    maintenanceCostPerYear : Float
  ) : async Result.Result<Bool, Text> {
    if (efficiencyPercentage < 0 or efficiencyPercentage > 100) {
      return #err("Verim yüzdesi 0 ile 100 arasında olmalıdır");
    };

    energySources.put(name, {
      name = name;
      efficiencyPercentage = efficiencyPercentage;
      annualOutputKwh = annualOutputKwh;
      installationCost = installationCost;
      maintenanceCostPerYear = maintenanceCostPerYear;
    });

    return #ok(true);
  };

  // Tüm enerji kaynaklarını listeleme
  public query func listEnergySources() : async [EnergySource] {
    Iter.toArray(
      Iter.map(
        energySources.entries(), 
        func((key,source) : EnergySource) { source }
      )
    );
  };

  // En verimli enerji kaynağını bulma
  public query func findMostEfficientSource() : async ?EnergySource {
    var mostEfficient : ?EnergySource = null;
    for (source in energySources.vals()) {
      switch (mostEfficient) {
        case (null) { mostEfficient := ?source; };
        case (?current) { 
          if (source.efficiencyPercentage > current.efficiencyPercentage) {
            mostEfficient := ?source;
          };
        };
      };
    };
    return mostEfficient;
  };

  // Yatırım getiri oranını (ROI) hesaplama
  public query func calculateROI(sourceName : Text) : async ?Float {
    switch (energySources.get(sourceName)) {
      case (null) { return null; };
      case (?source) {
        let annualRevenue = source.annualOutputKwh * 0.10; // kWh başına 0.10 $ varsayalım
        let totalAnnualCost = source.maintenanceCostPerYear;
        let roi = ((annualRevenue - totalAnnualCost) / source.installationCost) * 100.0;
        return ?roi;
      };
    };
  };

  // Sistemin başlangıç kurulumu
  public func initializeEnergySourceData() : async () {
    ignore addEnergySource(
      "Güneş Enerjisi", 
      20.5, 
      1500.0, 
      15000.0, 
      500.0
    );

    ignore addEnergySource(
      "Rüzgar Enerjisi", 
      35.7, 
      2200.0, 
      25000.0, 
      750.0
    );

    ignore addEnergySource(
      "Hidroelektrik Enerjisi", 
      45.2, 
      3000.0, 
      50000.0, 
      1000.0
    );
  };

  // Sistem sürüm bilgisi
  public query func getSystemVersion() : async Text {
    return "Yenilenebilir Enerji Analiz Sistemi v0.24.3";
  };
}