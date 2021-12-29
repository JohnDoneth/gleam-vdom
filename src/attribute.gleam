pub type Attribute {
  AText(String)
  ABool(Bool)
}

pub fn to_string(attribute: Attribute) -> String {
  case attribute {
    AText(text) -> text
    ABool(True) -> "true"
    ABool(False) -> "false"
  }
}
