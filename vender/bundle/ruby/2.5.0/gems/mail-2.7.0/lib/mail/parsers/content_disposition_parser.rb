
# frozen_string_literal: true
require 'mail/utilities'
require 'mail/parser_tools'




module Mail::Parsers
  module ContentDispositionParser
    extend Mail::ParserTools

    ContentDispositionStruct = Struct.new(:disposition_type, :parameters, :error)

    
class << self
	attr_accessor :_trans_keys
	private :_trans_keys, :_trans_keys=
end
self._trans_keys = [
	0, 0, 33, 126, 9, 126, 
	10, 10, 9, 32, 33, 
	126, 9, 126, 9, 40, 
	10, 10, 9, 32, 1, 244, 
	1, 244, 10, 10, 9, 
	32, 10, 10, 9, 32, 
	0, 244, 128, 191, 160, 191, 
	128, 191, 128, 159, 144, 
	191, 128, 191, 128, 143, 
	9, 40, 10, 10, 9, 32, 
	9, 126, 1, 244, 1, 
	244, 10, 10, 9, 32, 
	0, 244, 128, 191, 160, 191, 
	128, 191, 128, 159, 144, 
	191, 128, 191, 128, 143, 
	33, 126, 9, 59, 9, 59, 
	9, 126, 9, 59, 9, 
	59, 0, 0, 0
]

class << self
	attr_accessor :_key_spans
	private :_key_spans, :_key_spans=
end
self._key_spans = [
	0, 94, 118, 1, 24, 94, 118, 32, 
	1, 24, 244, 244, 1, 24, 1, 24, 
	245, 64, 32, 64, 32, 48, 64, 16, 
	32, 1, 24, 118, 244, 244, 1, 24, 
	245, 64, 32, 64, 32, 48, 64, 16, 
	94, 51, 51, 118, 51, 51, 0
]

class << self
	attr_accessor :_index_offsets
	private :_index_offsets, :_index_offsets=
end
self._index_offsets = [
	0, 0, 95, 214, 216, 241, 336, 455, 
	488, 490, 515, 760, 1005, 1007, 1032, 1034, 
	1059, 1305, 1370, 1403, 1468, 1501, 1550, 1615, 
	1632, 1665, 1667, 1692, 1811, 2056, 2301, 2303, 
	2328, 2574, 2639, 2672, 2737, 2770, 2819, 2884, 
	2901, 2996, 3048, 3100, 3219, 3271, 3323
]

class << self
	attr_accessor :_indicies
	private :_indicies, :_indicies=
end
self._indicies = [
	0, 0, 0, 0, 0, 0, 0, 1, 
	1, 0, 0, 0, 0, 0, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, 1, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 2, 
	1, 1, 1, 3, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 2, 4, 
	4, 4, 4, 4, 4, 4, 5, 1, 
	4, 4, 4, 4, 4, 1, 4, 4, 
	4, 4, 4, 4, 4, 4, 4, 4, 
	1, 1, 1, 1, 1, 1, 1, 4, 
	4, 4, 4, 4, 4, 4, 4, 4, 
	4, 4, 4, 4, 4, 4, 4, 4, 
	4, 4, 4, 4, 4, 4, 4, 4, 
	4, 1, 1, 1, 4, 4, 4, 4, 
	4, 4, 4, 4, 4, 4, 4, 4, 
	4, 4, 4, 4, 4, 4, 4, 4, 
	4, 4, 4, 4, 4, 4, 4, 4, 
	4, 4, 4, 4, 4, 1, 6, 1, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 2, 
	1, 7, 7, 7, 7, 7, 7, 7, 
	1, 1, 7, 7, 7, 7, 7, 1, 
	7, 7, 7, 7, 7, 7, 7, 7, 
	7, 7, 1, 1, 1, 8, 1, 1, 
	1, 7, 7, 7, 7, 7, 7, 7, 
	7, 7, 7, 7, 7, 7, 7, 7, 
	7, 7, 7, 7, 7, 7, 7, 7, 
	7, 7, 7, 1, 1, 1, 7, 7, 
	7, 7, 7, 7, 7, 7, 7, 7, 
	7, 7, 7, 7, 7, 7, 7, 7, 
	7, 7, 7, 7, 7, 7, 7, 7, 
	7, 7, 7, 7, 7, 7, 7, 1, 
	9, 1, 1, 1, 10, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 9, 
	11, 12, 11, 11, 11, 11, 11, 13, 
	1, 11, 11, 11, 11, 11, 1, 11, 
	11, 11, 11, 11, 11, 11, 11, 11, 
	11, 1, 1, 1, 11, 1, 1, 1, 
	11, 11, 11, 11, 11, 11, 11, 11, 
	11, 11, 11, 11, 11, 11, 11, 11, 
	11, 11, 11, 11, 11, 11, 11, 11, 
	11, 11, 1, 1, 1, 11, 11, 11, 
	11, 11, 11, 11, 11, 11, 11, 11, 
	11, 11, 11, 11, 11, 11, 11, 11, 
	11, 11, 11, 11, 11, 11, 11, 11, 
	11, 11, 11, 11, 11, 11, 1, 14, 
	1, 1, 1, 15, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 14, 1, 
	16, 1, 1, 1, 1, 1, 17, 1, 
	18, 1, 14, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 14, 1, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 1, 19, 19, 20, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 21, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 22, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 23, 23, 23, 23, 
	23, 23, 23, 23, 23, 23, 23, 23, 
	23, 23, 23, 23, 23, 23, 23, 23, 
	23, 23, 23, 23, 23, 23, 23, 23, 
	23, 23, 24, 25, 25, 25, 25, 25, 
	25, 25, 25, 25, 25, 25, 25, 26, 
	25, 25, 27, 28, 28, 28, 29, 1, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 1, 30, 30, 31, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 32, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 33, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 35, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 37, 36, 36, 38, 
	39, 39, 39, 40, 1, 41, 1, 30, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 30, 1, 
	42, 1, 43, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 43, 1, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 35, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	37, 36, 36, 38, 39, 39, 39, 40, 
	1, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 30, 30, 30, 30, 30, 30, 30, 
	30, 1, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 1, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 1, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 34, 34, 34, 34, 
	34, 34, 34, 34, 1, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 1, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 1, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 1, 
	44, 1, 1, 1, 45, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 44, 
	1, 46, 1, 1, 1, 1, 1, 47, 
	1, 48, 1, 49, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 49, 1, 50, 1, 1, 1, 
	51, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 50, 52, 52, 52, 52, 
	52, 52, 52, 53, 1, 52, 52, 52, 
	52, 52, 1, 52, 52, 52, 52, 52, 
	52, 52, 52, 52, 52, 1, 1, 1, 
	1, 1, 1, 1, 52, 52, 52, 52, 
	52, 52, 52, 52, 52, 52, 52, 52, 
	52, 52, 52, 52, 52, 52, 52, 52, 
	52, 52, 52, 52, 52, 52, 1, 1, 
	1, 52, 52, 52, 52, 52, 52, 52, 
	52, 52, 52, 52, 52, 52, 52, 52, 
	52, 52, 52, 52, 52, 52, 52, 52, 
	52, 52, 52, 52, 52, 52, 52, 52, 
	52, 52, 1, 54, 54, 54, 54, 54, 
	54, 54, 54, 54, 1, 54, 54, 55, 
	54, 54, 54, 54, 54, 54, 54, 54, 
	54, 54, 54, 54, 54, 54, 54, 54, 
	54, 54, 54, 54, 54, 54, 54, 54, 
	54, 54, 56, 57, 54, 54, 54, 54, 
	54, 54, 54, 54, 54, 54, 54, 54, 
	54, 54, 54, 54, 54, 54, 54, 54, 
	54, 54, 54, 54, 54, 54, 54, 54, 
	54, 54, 54, 54, 54, 54, 54, 54, 
	54, 54, 54, 54, 54, 54, 54, 54, 
	54, 54, 54, 54, 54, 54, 58, 54, 
	54, 54, 54, 54, 54, 54, 54, 54, 
	54, 54, 54, 54, 54, 54, 54, 54, 
	54, 54, 54, 54, 54, 54, 54, 54, 
	54, 54, 54, 54, 54, 54, 54, 54, 
	54, 54, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 59, 59, 59, 59, 
	59, 59, 59, 59, 59, 59, 59, 59, 
	59, 59, 59, 59, 59, 59, 59, 59, 
	59, 59, 59, 59, 59, 59, 59, 59, 
	59, 59, 60, 61, 61, 61, 61, 61, 
	61, 61, 61, 61, 61, 61, 61, 62, 
	61, 61, 63, 64, 64, 64, 65, 1, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 1, 66, 66, 67, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 68, 
	69, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 70, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 72, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 74, 73, 73, 75, 
	76, 76, 76, 77, 1, 78, 1, 66, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 66, 1, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	72, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 74, 73, 73, 
	75, 76, 76, 76, 77, 1, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 66, 66, 
	66, 66, 66, 66, 66, 66, 1, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 1, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	1, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 1, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 1, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 1, 73, 73, 73, 73, 
	73, 73, 73, 73, 73, 73, 73, 73, 
	73, 73, 73, 73, 1, 79, 79, 79, 
	79, 79, 79, 79, 1, 1, 79, 79, 
	79, 79, 79, 1, 79, 79, 79, 79, 
	79, 79, 79, 79, 79, 79, 1, 80, 
	1, 1, 1, 1, 1, 79, 79, 79, 
	79, 79, 79, 79, 79, 79, 79, 79, 
	79, 79, 79, 79, 79, 79, 79, 79, 
	79, 79, 79, 79, 79, 79, 79, 1, 
	1, 1, 79, 79, 79, 79, 79, 79, 
	79, 79, 79, 79, 79, 79, 79, 79, 
	79, 79, 79, 79, 79, 79, 79, 79, 
	79, 79, 79, 79, 79, 79, 79, 79, 
	79, 79, 79, 1, 81, 1, 1, 1, 
	82, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 81, 1, 1, 1, 1, 
	1, 1, 1, 83, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 84, 1, 
	85, 1, 1, 1, 86, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 85, 
	1, 1, 1, 1, 1, 1, 1, 87, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 88, 1, 89, 1, 1, 1, 
	90, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 89, 91, 1, 91, 91, 
	91, 91, 91, 92, 1, 91, 91, 91, 
	91, 91, 1, 91, 91, 91, 91, 91, 
	91, 91, 91, 91, 91, 1, 84, 1, 
	91, 1, 1, 1, 91, 91, 91, 91, 
	91, 91, 91, 91, 91, 91, 91, 91, 
	91, 91, 91, 91, 91, 91, 91, 91, 
	91, 91, 91, 91, 91, 91, 1, 1, 
	1, 91, 91, 91, 91, 91, 91, 91, 
	91, 91, 91, 91, 91, 91, 91, 91, 
	91, 91, 91, 91, 91, 91, 91, 91, 
	91, 91, 91, 91, 91, 91, 91, 91, 
	91, 91, 1, 49, 1, 1, 1, 93, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 49, 1, 1, 1, 1, 1, 
	1, 1, 94, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 2, 1, 95, 
	1, 1, 1, 96, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 95, 1, 
	1, 1, 1, 1, 1, 1, 97, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 50, 1, 1, 0
]

class << self
	attr_accessor :_trans_targs
	private :_trans_targs, :_trans_targs=
end
self._trans_targs = [
	40, 0, 2, 3, 5, 27, 4, 5, 
	6, 7, 8, 43, 10, 24, 7, 8, 
	10, 24, 9, 11, 12, 41, 16, 17, 
	18, 19, 20, 21, 22, 23, 11, 12, 
	41, 16, 17, 18, 19, 20, 21, 22, 
	23, 13, 15, 41, 7, 8, 10, 24, 
	26, 44, 2, 3, 5, 27, 29, 30, 
	29, 46, 32, 33, 34, 35, 36, 37, 
	38, 39, 29, 30, 29, 46, 32, 33, 
	34, 35, 36, 37, 38, 39, 31, 40, 
	2, 41, 14, 42, 2, 41, 14, 42, 
	2, 44, 25, 43, 45, 25, 45, 44, 
	25, 45
]

class << self
	attr_accessor :_trans_actions
	private :_trans_actions, :_trans_actions=
end
self._trans_actions = [
	1, 0, 0, 0, 2, 3, 0, 0, 
	4, 5, 5, 5, 5, 6, 0, 0, 
	0, 3, 0, 7, 7, 8, 7, 7, 
	7, 7, 7, 7, 7, 7, 0, 0, 
	9, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 10, 10, 10, 11, 
	0, 0, 10, 10, 12, 11, 13, 13, 
	14, 15, 13, 13, 13, 13, 13, 13, 
	13, 13, 0, 0, 3, 16, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	17, 18, 18, 19, 18, 20, 20, 21, 
	20, 18, 18, 0, 22, 0, 3, 10, 
	10, 11
]

class << self
	attr_accessor :_eof_actions
	private :_eof_actions, :_eof_actions=
end
self._eof_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	17, 18, 20, 18, 0, 10, 0
]

class << self
	attr_accessor :start
end
self.start = 1;
class << self
	attr_accessor :first_final
end
self.first_final = 40;
class << self
	attr_accessor :error
end
self.error = 0;

class << self
	attr_accessor :en_comment_tail
end
self.en_comment_tail = 28;
class << self
	attr_accessor :en_main
end
self.en_main = 1;



    def self.parse(data)
      data = data.dup.force_encoding(Encoding::ASCII_8BIT) if data.respond_to?(:force_encoding)

      content_disposition = ContentDispositionStruct.new('', [])
      return content_disposition if Mail::Utilities.blank?(data)

      # Parser state
      disp_type_s = param_attr_s = param_attr = qstr_s = qstr = param_val_s = nil

      # 5.1 Variables Used by Ragel
      p = 0
      eof = pe = data.length
      stack = []

      
begin
	p ||= 0
	pe ||= data.length
	cs = start
	top = 0
end

      
begin
	testEof = false
	_slen, _trans, _keys, _inds, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_keys = cs << 1
	_inds = _index_offsets[cs]
	_slen = _key_spans[cs]
	_wide = data[p].ord
	_trans = if (   _slen > 0 && 
			_trans_keys[_keys] <= _wide && 
			_wide <= _trans_keys[_keys + 1] 
		    ) then
			_indicies[ _inds + _wide - _trans_keys[_keys] ] 
		 else 
			_indicies[ _inds + _slen ]
		 end
	cs = _trans_targs[_trans]
	if _trans_actions[_trans] != 0
	case _trans_actions[_trans]
	when 1 then
		begin
 disp_type_s = p 		end
	when 17 then
		begin
 content_disposition.disposition_type = chars(data, disp_type_s, p-1).downcase 		end
	when 2 then
		begin
 param_attr_s = p 		end
	when 4 then
		begin
 param_attr = chars(data, param_attr_s, p-1) 		end
	when 7 then
		begin
 qstr_s = p 		end
	when 9 then
		begin
 qstr = chars(data, qstr_s, p-1) 		end
	when 5 then
		begin
 param_val_s = p 		end
	when 18 then
		begin

    if param_attr.nil?
      raise Mail::Field::ParseError.new(Mail::ContentDispositionElement, data, "no attribute for value")
    end

    # Use quoted string value if one exists, otherwise use parameter value
    value = qstr || chars(data, param_val_s, p-1)

    content_disposition.parameters << { param_attr => value }
    param_attr = nil
    qstr = nil
  		end
	when 10 then
		begin
 		end
	when 13 then
		begin
 		end
	when 3 then
		begin
 	begin
		stack[top] = cs
		top+= 1
		cs = 28
		_goto_level = _again
		next
	end
 		end
	when 16 then
		begin
 	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end
 		end
	when 8 then
		begin
 qstr_s = p 		end
		begin
 qstr = chars(data, qstr_s, p-1) 		end
	when 6 then
		begin
 param_val_s = p 		end
		begin
 	begin
		stack[top] = cs
		top+= 1
		cs = 28
		_goto_level = _again
		next
	end
 		end
	when 22 then
		begin

    if param_attr.nil?
      raise Mail::Field::ParseError.new(Mail::ContentDispositionElement, data, "no attribute for value")
    end

    # Use quoted string value if one exists, otherwise use parameter value
    value = qstr || chars(data, param_val_s, p-1)

    content_disposition.parameters << { param_attr => value }
    param_attr = nil
    qstr = nil
  		end
		begin
 	begin
		stack[top] = cs
		top+= 1
		cs = 28
		_goto_level = _again
		next
	end
 		end
	when 12 then
		begin
 		end
		begin
 param_attr_s = p 		end
	when 20 then
		begin
 		end
		begin

    if param_attr.nil?
      raise Mail::Field::ParseError.new(Mail::ContentDispositionElement, data, "no attribute for value")
    end

    # Use quoted string value if one exists, otherwise use parameter value
    value = qstr || chars(data, param_val_s, p-1)

    content_disposition.parameters << { param_attr => value }
    param_attr = nil
    qstr = nil
  		end
	when 11 then
		begin
 		end
		begin
 	begin
		stack[top] = cs
		top+= 1
		cs = 28
		_goto_level = _again
		next
	end
 		end
	when 14 then
		begin
 		end
		begin
 	begin
		stack[top] = cs
		top+= 1
		cs = 28
		_goto_level = _again
		next
	end
 		end
	when 15 then
		begin
 		end
		begin
 	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end
 		end
	when 19 then
		begin
 	begin
		stack[top] = cs
		top+= 1
		cs = 28
		_goto_level = _again
		next
	end
 		end
		begin

    if param_attr.nil?
      raise Mail::Field::ParseError.new(Mail::ContentDispositionElement, data, "no attribute for value")
    end

    # Use quoted string value if one exists, otherwise use parameter value
    value = qstr || chars(data, param_val_s, p-1)

    content_disposition.parameters << { param_attr => value }
    param_attr = nil
    qstr = nil
  		end
	when 21 then
		begin
 		end
		begin
 	begin
		stack[top] = cs
		top+= 1
		cs = 28
		_goto_level = _again
		next
	end
 		end
		begin

    if param_attr.nil?
      raise Mail::Field::ParseError.new(Mail::ContentDispositionElement, data, "no attribute for value")
    end

    # Use quoted string value if one exists, otherwise use parameter value
    value = qstr || chars(data, param_val_s, p-1)

    content_disposition.parameters << { param_attr => value }
    param_attr = nil
    qstr = nil
  		end
	end
	end
	end
	if _goto_level <= _again
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	  case _eof_actions[cs]
	when 17 then
		begin
 content_disposition.disposition_type = chars(data, disp_type_s, p-1).downcase 		end
	when 18 then
		begin

    if param_attr.nil?
      raise Mail::Field::ParseError.new(Mail::ContentDispositionElement, data, "no attribute for value")
    end

    # Use quoted string value if one exists, otherwise use parameter value
    value = qstr || chars(data, param_val_s, p-1)

    content_disposition.parameters << { param_attr => value }
    param_attr = nil
    qstr = nil
  		end
	when 10 then
		begin
 		end
	when 20 then
		begin
 		end
		begin

    if param_attr.nil?
      raise Mail::Field::ParseError.new(Mail::ContentDispositionElement, data, "no attribute for value")
    end

    # Use quoted string value if one exists, otherwise use parameter value
    value = qstr || chars(data, param_val_s, p-1)

    content_disposition.parameters << { param_attr => value }
    param_attr = nil
    qstr = nil
  		end
	  end
	end

	end
	if _goto_level <= _out
		break
	end
end
	end


      if p != eof || cs < 40
        raise Mail::Field::IncompleteParseError.new(Mail::ContentDispositionElement, data, p)
      end

      content_disposition
    end
  end
end
