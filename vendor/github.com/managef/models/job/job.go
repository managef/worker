package job

import (
	pb "github.com/managef/models/rpc"
	"context"
	"fmt"
	"github.com/managef/models/log"
)

type Server struct{}

// GetJob implements requests.JobServer

func (s *Server) GetJob(ctx context.Context, in *pb.JobRequest) (*pb.JobResponse, error) {
	log.Infof("[GET][Job]: Request: %+v\n", in)
	return &pb.JobResponse{Id: fmt.Sprintf("Hello Worker %d you reqested %+v", in.Id, in)}, nil
}