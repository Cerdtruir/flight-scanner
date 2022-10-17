class Flight < ApplicationRecord
  def self.flysafair_routes
    {
      'JNB' => %w[DUR CPT BFN ELS PLZ MRU GRJ HDS KIM LVI LUN BUQ HRE VFA SEZ],
      'CPT' => %w[JNB ELS HLA DUR BFN GRJ PLZ HDS],
      'DUR' => %w[JNB CPT ELS HLA BFN PLZ],
      'PLZ' => %w[JNB CPT DUR],
      'HLA' => %w[CPT DUR],
      'GRJ' => %w[JNB CPT BFN],
      'ELS' => %w[JNB CPT DUR],
      'BFN' => %w[JNB CPT DUR GRJ],
      'MRU' => %w[JNB],
      'VFA' => %w[JNB],
      'HRE' => %w[JNB],
      'BUQ' => %w[JNB],
      'HDS' => %w[JNB CPT],
      'LUN' => %w[JNB],
      'LVI' => %w[JNB],
      'KIM' => %w[JNB],
      'SEZ' => %w[JNB]
    }.freeze
  end
end
