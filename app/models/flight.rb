class Flight < ApplicationRecord
  def self.flysafair_routes
    {
      'JNB' => %w[DUR CPT BFN ELS PLZ MRU GRJ],
      'CPT' => %w[JNB ELS HLA DUR BFN GRJ PLZ],
      'DUR' => %w[JNB CPT ELS HLA BFN PLZ],
      'PLZ' => %w[JNB CPT DUR],
      'HLA' => %w[CPT DUR],
      'GRJ' => %w[JNB CPT BFN],
      'ELS' => %w[JNB CPT DUR],
      'BFN' => %w[JNB CPT DUR GRJ],
      'MRU' => %w[JNB]
    }.freeze
  end
end
