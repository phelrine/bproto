module Similarity
  def self.cosine_boolean(vec1, vec2)
    return 0 if vec1.size == 0 or vec2.size == 0
    inner_prod =  (vec1 & vec2).size
    regularize = Math.sqrt(vec1.size) * Math.sqrt(vec2.size)
    inner_prod / regularize
  end
end
