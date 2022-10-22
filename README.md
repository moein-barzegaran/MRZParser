# iOS assignment (Swift)

A machine-readable passport (MRP) is a machine-readable travel document (MRTD) with the data on the identity page encoded in optical character recognition format. (https://en.wikipedia.org/wiki/Machine-readable_passport).
Given an input string containing scanned MRZ lines, an `MRZInfo` class breaks this input data down into fields such as names, date of birth etc. Some fields in the MRZ contain a check digit, such as the document number, date of birth and expiration date. There is also an overall checksum at the end of the input string.
A description and examples of the checksum calculation can be found in https://www.icao.int/publications/Documents/9303_p3_cons_en.pdf
