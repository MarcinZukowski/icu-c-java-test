#include <assert.h>
#include <stdio.h>

#include <cstring>

#include <unicode/utf8.h>
#include <unicode/uenum.h>
#include <unicode/coll.h>
#include <unicode/sortkey.h>

using namespace std;
using namespace icu;

#define BUF_SIZE 1000000
static unsigned char outBuf[BUF_SIZE];
static char hexBuf[2 * BUF_SIZE];

void performConversion(Collator *m_collator, const char *in, size_t inLen, size_t *outLen)
{
  UErrorCode status = U_ZERO_ERROR;

  // Construct UnicodeString
  icu::StringPiece sp(in, inLen);
  icu::UnicodeString icuString = icu::UnicodeString::fromUTF8(sp);

  // Get collation key
  icu::CollationKey cltKey;
  m_collator->getCollationKey(icuString, cltKey, status);
  assert(U_SUCCESS(status));

  // Copy into our memory
  int32_t cltKeySize;
  const uint8_t *cltKeyBytes = cltKey.getByteArray(cltKeySize);

  assert(cltKeySize < BUF_SIZE);

  memcpy(outBuf, cltKeyBytes, cltKeySize);
  *outLen = cltKeySize;
}

static const char *hex = "0123456789ABCDEF";
void bin2hex(unsigned char *buf, int len, char *hexBuf)
{
    for (int i = 0; i < len; i++) {
      unsigned char c = buf[i] ;
      hexBuf[2*i+0] = hex[c >> 4];
      hexBuf[2*i+1] = hex[c & 15];
    }
    hexBuf[2*len] = 0;

}

int main(int argc, char **argv)
{
  assert(argc == 3);
  char *collateName = argv[1];
  char *inputFilename = argv[2];
  
  printf("%s\n", collateName);

  // Create a Collator
  UErrorCode status = U_ZERO_ERROR;
  Locale loc = Locale::createCanonical(collateName);
  Collator *clt= Collator::createInstance(loc, status);
  assert(U_SUCCESS(status));

  // Read file line by line
  FILE * fp;
  char * line = NULL;
  size_t len = 0;
  ssize_t read;

  fp = fopen(inputFilename, "r");
  assert(fp);

  while ((read = getline(&line, &len, fp)) != -1) {
    if (read <= 0)
      break;
    assert(read < BUF_SIZE);

    line[read - 1] = '\0';
    size_t inLen = read - 1;  // Skip \n
    
    if (line[0] == '#')
      continue;

    size_t outLen;

    performConversion(clt, line, inLen, &outLen);
    
    bin2hex(outBuf, outLen, hexBuf);

    printf("%3zd %3zd %-30s %-30s\n", inLen, outLen, line, hexBuf);
  }

  fclose(fp);
  if (line)
      free(line);
}
